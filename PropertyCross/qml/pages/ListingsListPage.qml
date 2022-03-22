import QtQuick 2.0
import Felgo 3.0

ListPage {

    id: listPageWrapper
    property var scrollPos: null
    property bool favorites

    rightBarItem: ActivityIndicatorBarItem {
        visible: dataModel.loading
    }

    model: JsonListModel {
        id: listModel
        source: favorites ? dataModel.favoriteListings : dataModel.listings
        fields: ["text", "detailText", "image", "model"]
    }

    title: favorites ? qsTr("favorite"): qsTr("%1 of %2 matches").arg(dataModel.numListings).arg(dataModel.numTotalListings)

    emptyText.text: favorites ? qsTr("No favorite chosen"): qsTr("No listings available")

    delegate: SimpleRow {
        item: listModel.get(index)
        autoSizeImage: true
        imageMaxSize: dp(40)
        image.fillMode: Image.PreserveAspectCrop

        onSelected: navigationStack.popAllExceptFirstAndPush(detailPageComponent, {model: item.model})
    }

    listView.footer: VisibilityRefreshHandler {
        visible: !favorites && dataModel.numListings < dataModel.numTotalListings

        onRefresh: {
            scrollPos = listView.getScrollPosition()
            logic.loadNextPage()
        }
    }

    Component {
        id: detailPageComponent
        ListingDetailPage {}
    }

}
