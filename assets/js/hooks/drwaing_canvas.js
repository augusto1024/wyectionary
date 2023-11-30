import throttle from '../utils/throttle';

export default CanvasHook = {
  mounted() {
    const width = 500;
    const height = 500;

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

    const editable = this.el.attributes.current_user.value === sessionStorage.getItem('user');

    editable && stage.on('mousedown touchstart', function (e) {
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

    editable && stage.on('mouseup touchend', function () {
      isPaint = false;
    });

    // and core function - drawing
    editable && stage.on('mousemove touchmove', function (e) {
      if (!isPaint) {
        return;
      }

      throttle(function () {
        // Send event to server
        this.pushEvent('canvas_updated', {stage: stage.toJSON()});
        // stage.toJSON();
      }.bind(this), 150);

      // prevent scrolling on touch devices
      e.evt.preventDefault();

      const pos = stage.getPointerPosition();
      const newPoints = lastLine.points().concat([pos.x, pos.y]);
      lastLine.points(newPoints);
    }.bind(this));

    this.handleEvent('canvas_updated', ({ stage: updatedStage }) => {
      updatedStage = JSON.parse(updatedStage)
      const updatedLayer = updatedStage.children[0]
      layer.destroyChildren()
      updatedLayer.children.forEach((child) => {
        layer.add(new Konva[child.className](child.attrs))
      })
    });
  },
};
