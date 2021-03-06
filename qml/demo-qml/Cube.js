var FRONT = 0
var LEFT = 1
var TOP = 2
var RIGHT = 3
var BOTTOM = 4

var DIRECTION_X = 1
var DIRECTION_Y = 2

var ORIENTATION_NEGATIVE = 1
var ORIENTATION_POSITIVE = 2

var direction = 0
var orientation = 0
var angle = 0
var origin = undefined
var moving = false
var startTime
var startPoint
var thresholdVelocity = 1000
var selectedFace
var lock = false

/* Resets the cube's orientation and angle and also restores to default all
rotation vectors */
function reset() {
    orientation = 0
    angle = 0

    /*** Y-axis rotation data reset ***/
    frontFaceRot.origin.x = 0
    frontFaceRot.origin.y = frontFaceContainer.height / 2

    leftFaceRot.origin.x = leftFaceContainer.width
    leftFaceRot.origin.y = leftFaceContainer.height / 2

    rightFaceRot.origin.x = 0
    rightFaceRot.origin.y = rightFaceContainer.height / 2

    /*** X-axis rotation data reset ***/
    topFaceRot.origin.x = topFaceContainer.width / 2
    topFaceRot.origin.y = topFaceContainer.height

    bottomFaceRot.origin.x = bottomFaceContainer.width / 2
    bottomFaceRot.origin.y = 0

    /*** angles reset ***/
    frontFaceRot.angle = 0
    leftFaceRot.angle = 270
    rightFaceRot.angle = 90
    topFaceRot.angle = 90
    bottomFaceRot.angle = 270
}

function getOrientation(delta) {
    if (delta < 0)
        return ORIENTATION_NEGATIVE
    return ORIENTATION_POSITIVE
}

function setFrontFaceRotation(direction, orientation) {
    frontFaceRot.axis.x = direction === DIRECTION_Y
    frontFaceRot.axis.y = direction === DIRECTION_X

    if (direction === DIRECTION_X) {
        if (orientation === 1) {
            frontFaceRot.origin.x = frontFaceContainer.width
            frontFaceRot.origin.y = frontFaceContainer.height / 2
        }
        else {
            frontFaceRot.origin.x = 0
            frontFaceRot.origin.y = frontFaceContainer.height / 2
        }
    }
    else {
        if (orientation === 1) {
            frontFaceRot.origin.x = frontFaceContainer.width / 2
            frontFaceRot.origin.y = 0
        }
        else {
            frontFaceRot.origin.x = frontFaceContainer.width / 2
            frontFaceRot.origin.y = frontFaceContainer.height
        }
    }
}

function mapToOrigin(mouse) {
    return [mouse.x - container.width / 2, -mouse.y - container.height / 2]
}

/* Initiates cube rotation */
function initRotation(mouse) {
    if (lock)
        return

    origin = mapToOrigin(mouse)
    startTime = new Date()
    startPoint = origin.slice()
}

function animate(mouse) {
    var fakeMouse = {"y": mouse.y, "x": mouse.x} // mouse properties are read-only
    for (var i = 0; i < 20; i++) {
        fakeMouse.y -= 1
        rotate(fakeMouse, true)
    }
}

/** Rotates the cube based on current mouse position. Once the cube rotation
axis is selected, the cube will rotate only around that given axis. */
function rotate(mouse, forced) {
    if (lock)
        return moving

    // first we need to map cursor's (0,0) coordinate, which points to top-left
    // corner cube's origin
    var coords = mapToOrigin(mouse)

    // now compute the axis along which to rotate
    if (!direction) {
        var dx = Math.abs(coords[0] - origin[0])
        var dy = Math.abs(coords[1] - origin[1])

        if (Math.max(dy, dx) < 20 && !forced)
            return moving

        if (dy > dx)
            direction = DIRECTION_Y
        else
            direction = DIRECTION_X

        rotationDirection = direction;
    }
    // the actual rotation is performed in this section
    else {
        moving = true
        var face = frontFaceContainer
        var faceRot = frontFaceRot
        var nextFace, nextFaceRot, a, o, delta

        rotationDirection = direction;

        // based on the direction and orientation values, the faces to be
        // rotated are determined dynamically and the rotation vectors of the
        // front face are updated accordingly
        if (direction == DIRECTION_X) {
            delta = coords[0] - origin[0]
            a = 90 * delta / container.width

            if (!orientation) {
                orientation = getOrientation(delta)
                faceRot.axis.x = 0
                faceRot.axis.y = 1
            }

            if (orientation == 1) {
                faceRot.origin.x = face.width
                faceRot.origin.y = face.height / 2
                nextFace = rightFaceContainer
                nextFaceRot = rightFaceRot
            }
            else {
                faceRot.origin.x = 0
                faceRot.origin.y = face.height / 2
                nextFace = leftFaceContainer
                nextFaceRot = leftFaceRot
            }
        }
        else {
            delta = coords[1] - origin[1]
            a = 90 * delta / container.height

            if (!orientation) {
                orientation = getOrientation(delta)
                faceRot.axis.x = 1
                faceRot.axis.y = 0
            }

            if (orientation == 1) {
                faceRot.origin.x = face.width / 2
                faceRot.origin.y = 0
                nextFace = topFaceContainer
                nextFaceRot = topFaceRot
            }
            else {
                faceRot.origin.x = face.width / 2
                faceRot.origin.y = face.height
                nextFace = bottomFaceContainer
                nextFaceRot = bottomFaceRot
            }
        }

        // update the origin for next delta computations
        origin = coords

        // check if we have reached the maximum rotation angle skip any
        // processing
        if (Math.abs(angle + a) >= 90)
            return moving

        angle += a

        // check if we have to switch to another face
        if (o != orientation && ((orientation == 1 && angle > 0) || (orientation == 2 && angle < 0))) {
            reset()
        }
        else {

            if (direction == DIRECTION_X) {
                face.x += delta
                nextFace.x += delta
                rotationPosition = face.x;
            }
            else {
                face.y += -delta
                nextFace.y += delta
                rotationPosition = face.y
            }

            faceRot.angle += a
            nextFaceRot.angle += a
        }
    }
    return moving
}

/** Call this function when the rotation is done. Returns the selected face */
function finishRotation(mouse) {
    if (lock)
        return
    else
        lock = true

    var dest = mapToOrigin(mouse)
    var elapsedTime = (new Date().getTime() - startTime.getTime()) / 1000
    var deltaPos = Math.max(Math.abs(dest[0] - startPoint[0]), Math.abs(dest[1] - startPoint[1]))

    moving = false

    if (Math.abs(angle) > 45 || deltaPos / elapsedTime > thresholdVelocity) {
        if (direction == DIRECTION_X) {
            if (orientation == 1)
                return RIGHT
            else
                return LEFT
        }
        else {
            if (orientation == 1)
                return TOP
            else
                return BOTTOM
        }
    }
    else
        return FRONT
}
