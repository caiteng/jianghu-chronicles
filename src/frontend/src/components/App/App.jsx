import Unity, { UnityContext } from "react-unity-webgl";
import { useState } from "react";
import { isMobile } from "react-device-detect";
import FadeLoader from "react-spinners/FadeLoader";
import "./app.css";
import logo from "../../assets/logo.png";

const unityContext = new UnityContext({
  loaderUrl: "files/WebGL.loader.js",
  dataUrl: "files/WebGL.data",
  frameworkUrl: "files/WebGL.framework.js",
  codeUrl: "files/WebGL.wasm",
});

function EnterFullScreen() {
  unityContext.setFullscreen(true);
}

function SetEnvironment() {
  // Timeout is required because of the splash screen,
  // so it takes a few seconds to load game scene.
  setTimeout(() => {
    let isProduction = window._env_.REACT_APP_ENV == "Production";
    let env = isProduction ? "Production" : "Development";

    unityContext.send("Environment Setter", "SetEnvCallback", env);
  }, 2000);
}

function MobileApp() {
  return (
    <div className="warning">
      <img src={logo} alt="logo" />
      <h1>江湖异闻录当前原型暂不支持移动端，请使用桌面浏览器体验。</h1>
    </div>
  );
}

function Logo() {
  return (
    <div>
      <img src={logo} className="logo" alt="logo" />
      <div className="title">
        <h2>江湖异闻录</h2>
      </div>
    </div>
  );
}

function FullScreenButton() {
  return (
    <div>
      <button onClick={EnterFullScreen} className="fullscreen-button">
        进入全屏
      </button>
    </div>
  );
}

function GitHubButton() {
  return (
    <div>
      <a
        href="https://github.com/caiteng/jianghu-chronicles"
        target="_blank"
        rel="noreferrer"
      >
        <button className="github-button">项目仓库</button>
      </a>
    </div>
  );
}

function Footer() {
  return (
    <div className="footer">
      <h4>技术原型版本 · 江湖异闻录</h4>
    </div>
  );
}

function App() {
  if (isMobile) {
    return <MobileApp />;
  }

  const [loading, setLoading] = useState(true);
  const fade = {
    style: { animation: `${"fade"} 1s` },
  };

  unityContext.on("loaded", () => setLoading(false));
  unityContext.on("SetEnv", SetEnvironment);

  return (
    <div>
      <div>
        <Logo />
        <div>
          {loading == false && (
            <div {...fade}>
              <FullScreenButton />
            </div>
          )}
          <GitHubButton />
        </div>
      </div>
      <div>
        <Unity className="container" unityContext={unityContext} />
      </div>
      <Footer />
      <div className="loader">
        <FadeLoader
          css={"display: block;"}
          size={50}
          color={"white"}
          loading={loading}
          speedMultiplier={1.5}
        />
      </div>
    </div>
  );
}

export default App;
