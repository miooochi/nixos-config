{ inputs, system, ... }:

# References:
# https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265/23
{
  programs.firefox = {
    enable = true;
    package = inputs.chaotic.packages.${system}.firefox_nightly;
    policies = {
      /* ---- PREFERENCES ---- */
      # Set preferences shared by all profiles.
      Preferences = {
        "browser.contentblocking.category" = { Value = "strict"; Status = "locked"; };
        "extensions.pocket.enabled" = {
          Value = true;
          Status = "locked";
        };
        "extensions.screenshots.disabled" = {
          Value = false;
          Status = "locked";
        };
      };
      /* ---- EXTENSIONS ---- */
      # To add any addons, manually install it then find the UUID in about:debugging#/runtime/this-firefox.
      ExtensionSettings = with builtins;
        let
          extension = shortId: uuid: {
            name = uuid;
            value = {
              install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
              installation_mode = "force_installed";
            };
          };
        in
        listToAttrs [
          # (extension "toby-for-tabs" "toby-ext@gettoby.com")
          (extension "tree-style-tab" "treestyletab@piro.sakura.ne.jp")
          (extension "ublock-origin" "uBlock0@raymondhill.net")
          (extension "bitwarden-password-manager" "{446900e4-71c2-419f-a6a7-df9c091e268b}")
          (extension "bookmarkhub" "{9c37f9a3-ea04-4a2b-9fcc-c7a814c14311}")
          (extension "link-redirect-trace" "{5327e982-d0be-4b85-b661-dba2ef210ab8}")
          (extension "octotree" "jid1-Om7eJGwA1U8Akg@jetpack")
          (extension "picture-in-picture" "{31a4c81b-add0-4ce4-b6e4-b54dcb0f4d1b}")
          (extension "pockettube" "danabok16@gmail.com")
          (extension "rsshub-radar" "i@diygod.me")
          (extension "tampermonkey" "firefox@tampermonkey.net")
          (extension "webrtc-control" "jid0-oFxt2GoakYukFl7Yp42Kq@jetpack")
          (extension "print-friendly-pdf" "jid0-YQz0l1jthOIz179ehuitYAOdBEs@jetpack")
        ];
    };
  };
}
