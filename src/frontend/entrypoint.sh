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

  function logRewrite(label, oldUrl, newUrl) {
    if (newUrl !== oldUrl) {
      console.log("[local-runtime-patch] " + label + " rewrite:", oldUrl, "=>", newUrl);
    }
  }

  function rewriteHttpUrl(url) {
    if (typeof url !== "string") return url;

    var rewritten = url
      .replace(/^https?:\/\/maplefighters\.io(?::\d+)?(?=\/|$)/, httpOrigin())
      .replace(/^https?:\/\/localhost(?::\d+)?(?=\/|$)/, httpOrigin())
      .replace(/^https?:\/\/127\.0\.0\.1(?::\d+)?(?=\/|$)/, httpOrigin());

    logRewrite("HTTP", url, rewritten);
    return rewritten;
  }

  function rewriteWsUrl(url) {
    if (typeof url !== "string") return url;

    var rewritten = url
      .replace(/^wss?:\/\/maplefighters\.io(?::\d+)?(?=\/|$)/, wsOrigin())
      .replace(/^wss?:\/\/localhost(?::\d+)?(?=\/|$)/, wsOrigin())
      .replace(/^wss?:\/\/127\.0\.0\.1(?::\d+)?(?=\/|$)/, wsOrigin());

    logRewrite("WS", url, rewritten);
    return rewritten;
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
      } else if (typeof Request !== "undefined" && input instanceof Request) {
        var rewrittenRequestUrl = rewriteHttpUrl(input.url);
        if (rewrittenRequestUrl !== input.url) {
          input = new Request(rewrittenRequestUrl, input);
        }
      } else if (input && input.url) {
        input.url = rewriteHttpUrl(input.url);
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
  window.WebSocket.CONNECTING = OriginalWebSocket.CONNECTING;
  window.WebSocket.OPEN = OriginalWebSocket.OPEN;
  window.WebSocket.CLOSING = OriginalWebSocket.CLOSING;
  window.WebSocket.CLOSED = OriginalWebSocket.CLOSED;

  console.log("[local-runtime-patch] enabled", window.location.origin);
})();
JS

  if ! grep -q "local-runtime-patch.js" /usr/share/nginx/html/index.html; then
    sed -i 's#</head>#<script src="/local-runtime-patch.js?v=3"></script></head>#' /usr/share/nginx/html/index.html
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
