import {
  AxisSetExtremesEventObject,
  Chart,
  Point, Pointer,
  PointerEventObject
} from "highcharts";

Pointer.prototype.reset = function() {
  return undefined;
};

export function highlightPoint(point: Point, event?: PointerEventObject) {
  const normalizedEvent = point.series.chart.pointer.normalize(event);
  point.onMouseOver(); // Show the hover marker
  // point.series.chart.tooltip.refresh(point); // Show the tooltip
  point.series.chart.xAxis[0].drawCrosshair(normalizedEvent, point); // Show the crosshair
}

export function syncExtremes(parentChart: Chart, childChart: Chart, event: AxisSetExtremesEventObject) {
  if (event.trigger === 'syncExtremes') return; // prevent infinite loop
  if (childChart === parentChart) return;
  if (!childChart.xAxis[0].setExtremes) return;

  childChart.xAxis[0].setExtremes(
      event.min,
      event.max,
      undefined,
      false,
      { trigger: 'syncExtremes' }
  );
}
