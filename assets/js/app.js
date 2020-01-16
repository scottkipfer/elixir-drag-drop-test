// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

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


import { Socket } from "phoenix"
import LiveSocket from "phoenix_live_view"

let Hooks = {};

Hooks.draggable_hook = {
  mounted() {
    this.el.addEventListener("dragstart", e => {
      e.dataTransfer.setData('text/plain', e.target.id);

      console.log('we be draggin', e.target.id);
    });
    this.el.addEventListener("dragover", e => {
      e.preventDefault();
      console.log('we be over', e.target.id);
    });
    this.el.addEventListener("dragenter", e => {
        this.el.classList.add("border-blue-500")
    })
    this.el.addEventListener("dragleave", e => {
        this.el.classList.remove("border-blue-500")
    })
    this.el.addEventListener("drop", e => {
      if (e.stopPropagation) e.stopPropagation(); // Stops some browsers from redirecting.
      

      let startId = e.dataTransfer.getData('text/plain');
      console.log('we be droppin ' + startId + ' => ' + e.target.id);
      this.el.classList.remove("border-blue-500")

    }, false);
  }
}

let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks})
liveSocket.connect()