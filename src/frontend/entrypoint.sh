#!/bin/sh

remove_cf_ips() {
  if [ "$REMOVE_CF_IPS" = "true" ]; then
    rm -f /var/www-allow/cloudflare-ips.conf
  fi
}

set_config() {
  sed -i "s|__REACT_APP_ENV__|${REACT_APP_ENV}|g" /usr/share/nginx/html/config.js
}

inject_runtime_patch() {
  cat > /usr/share/nginx/html/local-runtime-patch.js <<'JS'
(function () {
  function httpOrigin() {
    return window.location.origin;
  }

  function wsOrigin() {
    return (window.location.protocol === "https:" ? "wss://" : "ws://") + window.location.host;
  }

  function rewriteHttpUrl(url) {
    if (typeof url !== "string") return url;

    var old = url;
    url = url
      .replace(/^https?:\/\/maplefighters\.io(?::\d+)?(?=\/|$)/, httpOrigin())
      .replace(/^https?:\/\/localhost(?::\d+)?(?=\/|$)/, httpOrigin())
      .replace(/^https?:\/\/127\.0\.0\.1(?::\d+)?(?=\/|$)/, httpOrigin());

    if (url !== old) {
      console.log("[local-runtime-patch] HTTP rewrite:", old, "=>", url);
    }

    return url;
  }

  function rewriteWsUrl(url) {
    if (typeof url !== "string") return url;

    var old = url;
    url = url
      .replace(/^wss?:\/\/maplefighters\.io(?::\d+)?(?=\/|$)/, wsOrigin())
      .replace(/^wss?:\/\/localhost(?::\d+)?(?=\/|$)/, wsOrigin())
      .replace(/^wss?:\/\/127\.0\.0\.1(?::\d+)?(?=\/|$)/, wsOrigin());

    if (url !== old) {
      console.log("[local-runtime-patch] WS rewrite:", old, "=>", url);
    }

    return url;
  }

  var originalOpen = XMLHttpRequest.prototype.open;
  XMLHttpRequest.prototype.open = function (method, url) {
    arguments[1] = rewriteHttpUrl(url);
    return originalOpen.apply(this, arguments);
  };

  if (window.fetch) {
    var originalFetch = window.fetch;
    window.fetch = function (input, init) {
      if (typeof input === "string") {
        input = rewriteHttpUrl(input);
      } else if (input && input.url) {
        var rewritten = rewriteHttpUrl(input.url);
        if (rewritten !== input.url) {
          input = new Request(rewritten, input);
        }
      }
      return originalFetch.call(this, input, init);
    };
  }

  var OriginalWebSocket = window.WebSocket;
  window.WebSocket = function (url, protocols) {
    url = rewriteWsUrl(url);
    return protocols ? new OriginalWebSocket(url, protocols) : new OriginalWebSocket(url);
  };
  window.WebSocket.prototype = OriginalWebSocket.prototype;

  console.log("[local-runtime-patch] enabled:", window.location.origin);
})();
JS

  if ! grep -q "local-runtime-patch.js" /usr/share/nginx/html/index.html; then
    sed -i 's#</head>#<script src="/local-runtime-patch.js?v=2"></script></head>#' /usr/share/nginx/html/index.html
  fi
}

start_nginx() {
  exec nginx -g 'daemon off;'
}

main() {
  remove_cf_ips
  set_config
  inject_runtime_patch
  start_nginx
}

main
