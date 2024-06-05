class_name CameraSettings

## Inspector properties for follow modes
const FollowSettings = [
    {
        "flag": CineCamConstants.FollowProperties.TARGET,
        "object": {
				"name": "Follow Settings/Target",
				"type": TYPE_OBJECT,
				"class_name": &"Node3D",
				"hint": PROPERTY_HINT_NODE_TYPE,
				"hint_string": "Node3D",
		}
    },
    {
        "flag": CineCamConstants.FollowProperties.LOCK,
        "object": {
				"name": "Follow Settings/Lock Position",
				"type": TYPE_BOOL,
		}
    },
    {
        "flag": CineCamConstants.FollowProperties.SPEED,
        "object": {
				"name": "Follow Settings/Speed",
				"type": TYPE_FLOAT,
		}
    },
    {
        "flag": CineCamConstants.FollowProperties.IS_DAMPENED,
        "object": {
				"name": "Follow Settings/Is Dampened",
				"type": TYPE_BOOL,
		}
    },
	{
        "flag": CineCamConstants.FollowProperties.PATH_OFFSET,
        "object": {
				"name": "Follow Settings/Path Offset",
				"type": TYPE_FLOAT,
		}
    }, 
	{
        "flag": CineCamConstants.FollowProperties.MOVE_ALONG,
        "object": {
				"name": "Follow Settings/Move Along",
				"type": TYPE_BOOL,
		}
    }, 
	{
        "flag": CineCamConstants.FollowProperties.ROTATE_WITH_TARGET,
        "object": {
				"name": "Follow Settings/Rotate With Target",
				"type": TYPE_BOOL,
		}
    }, 
	{
        "flag": CineCamConstants.FollowProperties.LOOP,
        "object": {
				"name": "Follow Settings/Loop",
				"type": TYPE_BOOL,
		}
    },

    {
        "flag": CineCamConstants.FollowProperties.TARGET_OFFSET,
        "object": {
				"name": "Follow Settings/Offset",
				"type": TYPE_VECTOR3,
		}
    },
    {
        "flag": CineCamConstants.FollowProperties.TRACKING_PATH,
        "object": {
				"name": "Follow Settings/Tracking Path",
				"type": TYPE_OBJECT,
				"class_name": &"Path3D",
				"hint": PROPERTY_HINT_NODE_TYPE,
				"hint_string": "Path3D",
			}
    },
]

## Inspector properties for aim modes
const AimSettings = [
    {
        "flag": CineCamConstants.AimProperties.TARGET,
        "object": {
				"name": "Aim Settings/Target",
				"type": TYPE_OBJECT,
				"class_name": &"Node3D",
				"hint": PROPERTY_HINT_NODE_TYPE,
				"hint_string": "Node3D",
		}
    },
    {
        "flag": CineCamConstants.AimProperties.LOCK,
        "object": {
				"name": "Aim Settings/Lock Aim",
				"type": TYPE_BOOL,
		}
    },
]
