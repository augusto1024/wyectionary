export default CanvasHook = {
  mounted() {
    const width = window.innerWidth;
    const height = window.innerHeight - 25;

    // first we need Konva core things: stage and layer
    const stage = new Konva.Stage({
      container: this.el.id,
      width: width,
      height: height,
    });

    const layer = new Konva.Layer();
    stage.add(layer);

    let isPaint = false;
    let lastLine;

    stage.on('mousedown touchstart', function (e) {
      isPaint = true;
      const pos = stage.getPointerPosition();
      lastLine = new Konva.Line({
        stroke: '#df4b26',
        strokeWidth: 5,
        globalCompositeOperation: 'source-over',
        // round cap for smoother lines
        lineCap: 'round',
        lineJoin: 'round',
        // add point twice, so we have some drawings even on a simple click
        points: [pos.x, pos.y, pos.x, pos.y],
      });
      layer.add(lastLine);
    });

    stage.on('mouseup touchend', function () {
      isPaint = false;
    });

    // and core function - drawing
    stage.on('mousemove touchmove', function (e) {
      if (!isPaint) {
        return;
      }

      // prevent scrolling on touch devices
      e.evt.preventDefault();

      const pos = stage.getPointerPosition();
      const newPoints = lastLine.points().concat([pos.x, pos.y]);
      lastLine.points(newPoints);
    });
  },
};
