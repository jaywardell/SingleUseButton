#  SingleUseButton

This is a button that can be tapped once and then becomes disabled and shows a different title and icon, with a little animation.

## Usage:

Use it like a regular button, but know that it can only take title and system image name parameters:

    SingleUseButton(
        actionTitle: "Bookmark",
        actionImageName: "bookmark",
        finishedTitle: "Bookmarked",
        finishedImageName: "checkmark"
    ) {
        print("bookmark button was pressed")
    }

The system image names are optional and can be ignored:

    SingleUseButton(
        actionTitle: "Delete",
        finishedTitle: "Deleted",
    ) {
        print("bookmark button was pressed")
    }

And you can provide a different border shape, but it must be provided on init:

    SingleUseButton(
        actionTitle: "Find My Location",
        actionImageName: "location.magnifyingglass",
        finishedTitle: "Location Found",
        finishedImageName: "globe",
        shape: Capsule()
    ) {
        print("bookmark button was pressed")
    }

