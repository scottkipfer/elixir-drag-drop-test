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
import { polyfill } from "mobile-drag-drop"
polyfill();

let Hooks = {};

Hooks.draggable_hook = {
  mounted() {
    this.el.addEventListener("dragstart", e => {
      let data = JSON.stringify({id: e.target.id, pos: e.target.attributes.pos.value});
      e.dataTransfer.setData('text/plain', data);
    });
    this.el.addEventListener("dragover", e => { e.preventDefault();});
    this.el.addEventListener("dragenter", e => {
      e.preventDefault();
      this.el.classList.add("border-blue-500")
    })
    this.el.addEventListener("dragleave", e => {
      this.el.classList.remove("border-blue-500")
    })
    this.el.addEventListener("drop", e => {
      if (e.stopPropagation) e.stopPropagation(); // Stops some browsers from redirecting.
      let { id, pos } = JSON.parse(e.dataTransfer.getData('text/plain'));
      let dropId = e.target.id;
      let dropPos = e.target.attributes.pos.value;
      this.el.classList.remove("border-blue-500")

      console.log('we be droppin ' + id + '(' +  pos + ')' + ' => ' + dropId + '(' + dropPos +')');

      if (pos !== dropPos) {
        pos < dropPos 
          ?
          this.pushEvent("move_after", {
            "startId": id,
            "endId": dropId
          })
          : 
          this.pushEvent("move_before", {
            "startId": id,
            "endId": dropId
          })
      }

    }, false);
  },
}


let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks})
liveSocket.connect()