export default CopyToClipboard = {
  mounted() {
    let { to } = this.el.dataset;
    this.el.addEventListener("click", (ev) => {
      ev.preventDefault();
      let text = document.querySelector(to).innerText;
      navigator.clipboard.writeText(text);
    });
  },
};
