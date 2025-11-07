// Arch Linux Wayland - Optimized Firefox config
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

/*** WAYLAND ***/
user_pref("widget.use-xdg-desktop-portal.file-picker", 1);
user_pref("widget.use-xdg-desktop-portal.mime-handler", 1);
user_pref("media.ffmpeg.vaapi.enabled", true); // hw video decode (VA-API)

/*** GFX ***/
user_pref("gfx.webrender.all", true);
user_pref("gfx.webrender.precache-shaders", true);
user_pref("gfx.webrender.program-binary-disk", true);
user_pref("gfx.webrender.compositor", true);
user_pref("gfx.webrender.compositor.force-enabled", true);
user_pref("gfx.canvas.accelerated", true);
user_pref("gfx.canvas.accelerated.cache-items", 16384);
user_pref("gfx.canvas.accelerated.cache-size", 1024);
user_pref("gfx.content.skia-font-cache-size", 32);
user_pref("layout.animation.prerender.partial", true);
user_pref("layout.css.font-visibility.level", 2);
user_pref("layers.gpu-process.enabled", true);
user_pref("layers.gpu-process.force-enabled", true);
user_pref("media.hardware-video-decoding.force-enabled", true);
user_pref("media.av1.enabled", true);
user_pref("media.ffmpeg.low-latency.enabled", true);

/*** CACHE ***/
user_pref("browser.cache.memory.enable", true);
user_pref("browser.cache.memory.capacity", -1);
user_pref("browser.cache.memory.max_entry_size", 10240);
user_pref("browser.cache.disk.enable", true); // tmpfs /tmp on Arch
user_pref("browser.cache.disk.smart_size.enabled", true);
user_pref("browser.cache.disk.capacity", 512000);
user_pref("browser.cache.disk.max_entry_size", 102400);
user_pref("browser.cache.disk.metadata_memory_limit", 1024);
user_pref("browser.cache.disk.max_chunks_memory_usage", 81920);
user_pref("browser.cache.disk.max_priority_chunks_memory_usage", 81920);
user_pref("browser.cache.disk_cache_ssl", true);
user_pref("browser.cache.jsbc_compression_level", 3);
user_pref("dom.compression_streams.zstd.enabled", true);
user_pref("image.mem.decode_bytes_at_a_time", 65536);
user_pref("image.cache.size", 10485760);
user_pref("media.memory_cache_max_size", 131072);
user_pref("media.memory_caches_combined_limit_kb", 1048576);
user_pref("media.memory_caches_combined_limit_pc_sysmem", 10);
user_pref("media.cache_readahead_limit", 7200);
user_pref("media.cache_resume_threshold", 3600);

/*** NETWORK ***/
user_pref("network.http.max-connections", 1800);
user_pref("network.http.max-persistent-connections-per-server", 20);
user_pref("network.http.max-urgent-start-excessive-connections-per-host", 10);
user_pref("network.http.pacing.requests.enabled", false); // faster on fast conns
user_pref("network.http.rcwn.enabled", false); // cache > network
user_pref("network.http.http2.aggressive_coalescing", true);
user_pref("network.http.http2.push_priority_update", true);
user_pref("network.http.http3.enable", true);
user_pref("network.http.http3.version_negotiation.enabled", true);
user_pref("network.http.http3.send_background_tabs_deprioritization", true);
user_pref("network.http.speculative-parallel-limit", 24);
user_pref("network.http.referer.XOriginTrimmingPolicy", 2);
user_pref("network.http.referer.trimmingPolicy", 2);
user_pref("network.buffer.cache.size", 262144);
user_pref("network.buffer.cache.count", 64);
user_pref("network.ssl_tokens_cache_capacity", 32768);
user_pref("network.dnsCacheEntries", 2000);
user_pref("network.dnsCacheExpiration", 3600);
user_pref("network.dnsCacheExpirationGracePeriod", 300);
user_pref("network.dns.max_high_priority_threads", 64);
user_pref("network.dns.max_any_priority_threads", 32);
user_pref("network.dns.disablePrefetch", false);
user_pref("network.dns.disablePrefetchFromHTTPS", false);
user_pref("network.prefetch-next", true);
user_pref("network.predictor.enabled", true);
user_pref("network.predictor.enable-prefetch", true);
user_pref("network.modulepreload", true);
user_pref("network.early-hints.enabled", true);
user_pref("network.early-hints.preconnect.enabled", true);
user_pref("network.early-hints.preconnect.max_connections", 16);
user_pref("network.fetchpriority.enabled", true);
user_pref("browser.urlbar.speculativeConnect.enabled", true);
user_pref("browser.places.speculativeConnect.enabled", true);
user_pref("network.trr.mode", 5); // DoH off (use system resolver)

/*** JS/WASM ***/
user_pref("javascript.options.baselinejit.threshold", 50);
user_pref("javascript.options.ion.threshold", 500);
user_pref("javascript.options.wasm_ionjit", true);
user_pref("javascript.options.wasm_gc", true);
user_pref("javascript.options.wasm_branch_hinting", true);
user_pref("javascript.options.wasm_lazy_tiering", true);
user_pref("javascript.options.wasm_lazy_tiering_for_gc", true);
user_pref("javascript.options.wasm_lazy_tiering_synchronous", false);
user_pref("javascript.options.wasm_relaxed_simd", true);
user_pref("javascript.options.wasm_tail_calls", true);
user_pref("javascript.options.wasm_unroll_loops", true);
user_pref("javascript.options.wasm_moz_intgemm", true);

/*** PROCESS ***/
user_pref("dom.ipc.processCount", 8);
user_pref("dom.ipc.processCount.webIsolated", 2);
user_pref("dom.ipc.processPrelaunch.fission.number", 3);
user_pref("dom.ipc.forkserver.enable", true);
user_pref("dom.ipc.processPriorityManager.backgroundUsesEcoQoS", true);
user_pref("dom.iframe_lazy_loading.enabled", true);
user_pref("content.notify.interval", 100000);
user_pref("browser.sessionhistory.max_total_viewers", 10);
user_pref("browser.tabs.unloadOnLowMemory", true);
user_pref("browser.low_commit_space_threshold_mb", 4096);
user_pref("browser.tabs.min_inactive_duration_before_unload", 300000);

/*** DB ***/
user_pref("dom.indexedDB.preprocessing", true);
user_pref("dom.indexedDB.logging.enabled", false);
user_pref("dom.quotaManager.temporaryStorage.lazyOriginInitialization", true);

/*** MEDIA ***/
user_pref("media.mediasource.webm.enabled", true);
user_pref("media.gmp.decoder.multithreaded", true);
user_pref("media.gmp.encoder.multithreaded", true);
user_pref("media.gmp.decoder.decode_batch", true);
user_pref("media.decoder.recycle.enabled", true);
user_pref("media.av1.new-thread-count-strategy", true);
user_pref("media.webrtc.hw.h264.enabled", true);
user_pref("media.webrtc.simulcast.av1.enabled", false);
user_pref("media.peerconnection.video.vp9_preferred", true);
user_pref("image.decode-immediately.enabled", true);
user_pref("image.jxl.enabled", true);
user_pref("media.videocontrols.picture-in-picture.enabled", false);
user_pref("media.webspeech.synth.enabled", false);
user_pref("media.block-autoplay-until-in-foreground", true);

/*** PRIVACY ***/
user_pref("browser.contentblocking.category", "strict");
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.pbmode.enabled", true);
user_pref("privacy.trackingprotection.cryptomining.enabled", true);
user_pref("privacy.trackingprotection.emailtracking.enabled", true);
user_pref("privacy.trackingprotection.lower_network_priority", true);
user_pref("privacy.fingerprintingProtection", true);
user_pref("privacy.globalprivacycontrol.enabled", true);
user_pref("privacy.globalprivacycontrol.functionality.enabled", true);
user_pref("privacy.globalprivacycontrol.pbmode.enabled", true);
user_pref("privacy.donottrackheader.enabled", true);
user_pref("privacy.query_stripping.enabled", true);
user_pref("privacy.partition.always_partition_third_party_non_cookie_storage", true);
user_pref("privacy.firstparty.isolate", false); // conflicts with ETP strict
user_pref("network.cookie.cookieBehavior", 5); // total cookie protection
user_pref("cookiebanners.service.mode", 2);
user_pref("cookiebanners.service.mode.privateBrowsing", 2);
user_pref("cookiebanners.service.enableGlobalRules", true);
user_pref("cookiebanners.service.enableGlobalRules.subFrames", true);
user_pref("dom.private-attribution.submission.enabled", false);
user_pref("extensions.webcompat.enable_shims", true);
user_pref("urlclassifier.trackingSkipURLs", "*.reddit.com, *.twitter.com, *.twimg.com, *.tiktok.com");
user_pref("urlclassifier.features.socialtracking.skipURLs", "*.instagram.com, *.twitter.com, *.twimg.com");

/*** SECURITY ***/
user_pref("security.tls.enable_0rtt_data", true);
user_pref("security.OCSP.enabled", 0);
user_pref("security.pki.crlite_mode", 2);
user_pref("security.remote_settings.crlite_filters.enabled", true);
user_pref("security.dialog_enable_delay", 0);
user_pref("pdfjs.enableScripting", false);
user_pref("webgl.enable-debug-renderer-info", false);

/*** TELEMETRY ***/
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.server", "data:,");
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false);
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
user_pref("toolkit.telemetry.updatePing.enabled", false);
user_pref("toolkit.telemetry.bhrPing.enabled", false);
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
user_pref("toolkit.telemetry.coverage.opt-out", true);
user_pref("toolkit.coverage.opt-out", true);
user_pref("toolkit.coverage.endpoint.base", "");
user_pref("app.normandy.enabled", false);
user_pref("app.normandy.api_url", "");
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);
user_pref("browser.discovery.enabled", false);
user_pref("browser.send_pings", false);
user_pref("browser.search.serpEventTelemetryCategorization.enabled", false);
user_pref("beacon.enabled", false);
user_pref("corroborator.enabled", false);
user_pref("breakpad.reportURL", "");
user_pref("browser.tabs.crashReporting.sendReport", false);
user_pref("browser.crashReports.unsubmittedCheck.autoSubmit2", false);
user_pref("network.connectivity-service.enabled", false);
user_pref("default-browser-agent.enabled", false);
user_pref("extensions.abuseReport.enabled", false);
user_pref("dom.security.unexpected_system_load_telemetry_enabled", false);
user_pref("network.trr.confirmation_telemetry_enabled", false);
user_pref("security.app_menu.recordEventTelemetry", false);
user_pref("security.certerrors.recordEventTelemetry", false);
user_pref("security.protectionspopup.recordEventTelemetry", false);
user_pref("privacy.trackingprotection.emailtracking.data_collection.enabled", false);
user_pref("messaging-system.askForFeedback", false);
user_pref("extensions.logging.enabled", false);
user_pref("browser.search.log", false);

/*** GEO/SENSORS ***/
user_pref("geo.enabled", false);
user_pref("geo.provider.network.url", "");
user_pref("permissions.default.geo", 2);
user_pref("permissions.default.desktop-notification", 2);
user_pref("permissions.default.camera", 2);
user_pref("dom.webnotifications.enabled", false);
user_pref("dom.webnotifications.serviceworker.enabled", false);
user_pref("dom.event.clipboardevents.enabled", false);
user_pref("dom.battery.enabled", false);
user_pref("dom.gamepad.enabled", false);
user_pref("dom.gamepad.haptic_feedback.enabled", false);
user_pref("dom.vibrator.enabled", false);
user_pref("device.sensors.enabled", false);
user_pref("device.sensors.ambientLight.enabled", false);
user_pref("device.sensors.motion.enabled", false);
user_pref("device.sensors.orientation.enabled", false);
user_pref("device.sensors.proximity.enabled", false);
user_pref("media.navigator.enabled", false);

/*** UI/UX ***/
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.aboutConfig.showWarning", false);
user_pref("browser.aboutwelcome.enabled", false);
user_pref("browser.newtabpage.enabled", false);
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.showWeather", false);
user_pref("browser.newtabpage.activity-stream.default.sites", "");
user_pref("browser.newtab.preload", false);
user_pref("browser.library.activity-stream.enabled", false);
user_pref("browser.urlbar.suggest.engines", false);
user_pref("browser.urlbar.suggest.topsites", false);
user_pref("browser.urlbar.suggest.weather", false);
user_pref("browser.urlbar.suggest.calculator", false);
user_pref("browser.urlbar.suggest.clipboard", false);
user_pref("browser.urlbar.suggest.pocket", false);
user_pref("browser.urlbar.trending.featureGate", false);
user_pref("browser.urlbar.showSearchTerms.enabled", false);
user_pref("browser.urlbar.trimHttps", true);
user_pref("browser.tabs.insertRelatedAfterCurrent", true);
user_pref("browser.tabs.hoverPreview.enabled", false);
user_pref("browser.tabs.warnOnClose", true);
user_pref("browser.download.alwaysOpenPanel", false);
user_pref("browser.download.open_pdf_attachments_inline", true);
user_pref("browser.download.start_downloads_in_tmp_dir", true);
user_pref("browser.download.manager.addToRecentDocs", false);
user_pref("browser.menu.showViewImageInfo", true);
user_pref("browser.compactmode.show", true);
user_pref("browser.preferences.moreFromMozilla", false);
user_pref("browser.messaging-system.whatsNewPanel.enabled", false);
user_pref("browser.uitour.enabled", false);
user_pref("browser.vpn_promo.enabled", false);
user_pref("browser.privatebrowsing.vpnpromourl", "");
user_pref("browser.sessionstore.interval", 60000);
user_pref("browser.sessionstore.privacy_level", 0);
user_pref("browser.startup.homepage_override.mstone", "ignore");
user_pref("layout.word_select.eat_space_to_next_word", true);
user_pref("layout.css.prefers-color-scheme.content-override", 0);
user_pref("ui.prefersReducedMotion", 1);
user_pref("ui.systemUsesDarkTheme", 1);
user_pref("toolkit.cosmeticAnimations.enabled", false);
user_pref("sidebar.animation.enabled", false);
user_pref("full-screen-api.warning.timeout", 0);
user_pref("full-screen-api.warning.delay", -1);
user_pref("full-screen-api.transition-duration.enter", "0 0");
user_pref("full-screen-api.transition-duration.leave", "0 0");
user_pref("browser.fullscreen.animateUp", false);

/*** EXTENSIONS ***/
user_pref("extensions.pocket.enabled", false);
user_pref("extensions.getAddons.showPane", false);
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
user_pref("extensions.screenshots.disabled", true);
user_pref("extensions.screenshots.upload-disabled", true);
user_pref("extensions.webcompat-reporter.enabled", false);
user_pref("extensions.webextensions.restrictedDomains", "");
user_pref("extensions.autoDisableScopes", 11);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);
user_pref("signon.firefoxRelay.feature", "");

/*** EXPERIMENTAL ***/
user_pref("layout.css.grid-template-masonry-value.enabled", true);
user_pref("dom.enable_web_task_scheduling", true);
user_pref("dom.element.blocking.enabled", true);
user_pref("accessibility.force_disabled", 1);
user_pref("reader.parse-on-load.enabled", false);
user_pref("narrate.enabled", false);
user_pref("print.enabled", false);
user_pref("browser.bookmarks.max_backups", 2);
user_pref("media.video_stats.enabled", false);
