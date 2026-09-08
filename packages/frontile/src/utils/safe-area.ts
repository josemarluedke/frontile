/**
 * The "safe area" a pointer may travel through on its way from a submenu
 * trigger to the submenu itself.
 *
 * A submenu that closed the instant the pointer left its trigger row would be
 * unusable: the pointer has to cross a gap, and it crosses it diagonally
 * because the submenu is offset downward from the row that opened it. The safe
 * area is the trigger rect, the content rect, and the polygon that fans out
 * from the trigger's facing edge to cover the whole content rect -- so a
 * pointer aimed at the submenu keeps it open, while one heading for a sibling
 * row leaves immediately and closes it.
 *
 * Pure functions over plain rects: the fiddliest part of the interaction is
 * therefore testable without a browser, and the placement (left or right of
 * the trigger, possibly flipped by floating-ui) is derived from the rects
 * rather than passed in and trusted.
 */

interface Point {
  x: number;
  y: number;
}

type Rect = Pick<DOMRect, 'top' | 'right' | 'bottom' | 'left'>;

/** Inclusive of the edges: a pointer exactly on the border is still inside. */
function isPointInRect(point: Point, rect: Rect): boolean {
  return (
    point.x >= rect.left &&
    point.x <= rect.right &&
    point.y >= rect.top &&
    point.y <= rect.bottom
  );
}

/**
 * The bridge from the trigger's facing edge to the content rect.
 *
 * Which edge faces the content is decided by the rects: floating-ui's flip
 * middleware can put the submenu on either side, and a polygon built for the
 * wrong side would make every pointer movement unsafe.
 */
function buildSafeAreaPolygon(trigger: Rect, content: Rect): Point[] {
  const opensRight =
    content.left + content.right >= trigger.left + trigger.right;

  const edgeX = opensRight ? trigger.right : trigger.left;
  const nearX = opensRight ? content.left : content.right;
  const farX = opensRight ? content.right : content.left;

  return [
    { x: edgeX, y: trigger.top },
    { x: nearX, y: content.top },
    { x: farX, y: content.top },
    { x: farX, y: content.bottom },
    { x: nearX, y: content.bottom },
    { x: edgeX, y: trigger.bottom }
  ];
}

/**
 * Ray casting: count the polygon edges a ray from the point crosses. An odd
 * count means inside. Chosen over a winding number because the polygon above
 * is always simple (non-self-intersecting), which is the case ray casting
 * handles without caveats.
 */
function isPointInPolygon(point: Point, polygon: Point[]): boolean {
  let isInside = false;

  for (let i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    const a = polygon[i] as Point;
    const b = polygon[j] as Point;

    const straddlesRay = a.y > point.y !== b.y > point.y;
    if (!straddlesRay) {
      continue;
    }

    const crossingX = ((b.x - a.x) * (point.y - a.y)) / (b.y - a.y) + a.x;
    if (point.x < crossingX) {
      isInside = !isInside;
    }
  }

  return isInside;
}

function isPointInSafeArea(
  point: Point,
  trigger: Rect,
  content: Rect
): boolean {
  return (
    isPointInRect(point, trigger) ||
    isPointInRect(point, content) ||
    isPointInPolygon(point, buildSafeAreaPolygon(trigger, content))
  );
}

export {
  isPointInRect,
  buildSafeAreaPolygon,
  isPointInPolygon,
  isPointInSafeArea,
  type Point,
  type Rect
};
