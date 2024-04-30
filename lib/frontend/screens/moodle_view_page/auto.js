var password = "Asuka081046";
var email = "aozora.etoil@moegi.waseda.jp";
(async () => {
  try {
    await (function (e, ...r) {
      const s = t.get(),
        n = Math.random().toString(36).slice(2);
      return new Promise((a, t) => {
        const m = (e) => {
          if (e.id === n)
            if ((s.onMessage.removeListener(m), "iter" in e)) {
              const e = (async function* () {
                let e;
                for (;;) {
                  const r = await new Promise((r, a) => {
                    const t = (e) => {
                      e.id === n &&
                        (s.onMessage.removeListener(t),
                        "iter_next" in e
                          ? r(e.iter_next.value)
                          : "error" in e
                          ? a(g(e.error))
                          : console.error("invalid message", e));
                    };
                    s.onMessage.addListener(t),
                      s.postMessage({ id: n, iter_next: { value: e } });
                  });
                  if (r.done) return r.value;
                  e = yield r.value;
                }
              })();
              a(e);
            } else
              "ret" in e
                ? a(e.ret.value)
                : "error" in e
                ? t(g(e.error))
                : console.error("invalid message", e);
        };
        s.onMessage.addListener(m),
          s.postMessage({ id: n, command: e, args: r });
      });
    })("doAutoLogin", { skipCheck: !0, skipSessionKey: !0 });
    const e = new URLSearchParams(location.search).get("redirectUrl");
    location.replace(e ?? "https://wsdmoodle.waseda.jp/");
  } catch (e) {
    location.replace(
      "https://wsdmoodle.waseda.jp/auth/saml2/login.php?wants=https%3A%2F%2Fwsdmoodle.waseda.jp%2F&idp=fcc52c5d2e034b1803ea1932ae2678b0&passive=off"
    );
  }
})();
