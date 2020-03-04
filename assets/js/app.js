// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"
import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"
import * as bs from "./bert-serializer"
import IntersectionObserverAdmin from 'intersection-observer-admin';

let Hooks = {}

const observerAdmin = new IntersectionObserverAdmin();
const sentinelOptions = { rootMargin: '0px 0px 90px 0px', threshold: 0 };
const observerOptions = { rootMargin: '0px 0px 0px 0px', threshold: 0 };

Hooks.ObserverInfiniteScroll = {
  observerAdmin,
  page() { return this.el.dataset.page },
  mounted(){
    this.pending = this.page()
    let enterCallback = ({ target }) => {
      if (this.pending == this.page()) {
        this.pending = this.page() + 1
        this.pushEvent("load-more", {})
      }
    }

    let exitCallback = ({ isIntersecting, target }) => {
      if (isIntersecting) {
        this.observerAdmin.unobserve(target, sentinelOptions);
      }
    }

    this.observerAdmin.addEnterCallback(
      this.el,
      enterCallback.bind(this)
    )
    this.observerAdmin.addExitCallback(
      this.el,
      exitCallback.bind(this)
    )

    this.observerAdmin.observe(
      this.el,
      sentinelOptions
    )
  },

  // after DOM Patch
  updated(){ this.pending = this.page() }
}

Hooks.LazyArtwork = {
  observerAdmin,
  artwork() { return this.el.querySelector('img') },

  mounted() {
    window.requestIdleCallback(() => {
      let enterCallback = ({ target: img }) => {
        if (img) {
            if (img && img.dataset) {
              // img.src = img.dataset.src;
            }
        }
      }

      let exitCallback = ({ isIntersecting, target: img }) => {
        if (isIntersecting) {
          this.observerAdmin.unobserve(img, observerOptions);
        }
      }

      const artwork = this.artwork();
      this.observerAdmin.addEnterCallback(
        artwork,
        enterCallback
      )
      this.observerAdmin.addExitCallback(
        artwork,
        exitCallback
      )

      this.observerAdmin.observe(
        artwork,
        observerOptions
      )
    });
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}, decode: bs.decode });

liveSocket.connect();

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
