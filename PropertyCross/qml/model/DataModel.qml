import QtQuick 2.0
import Felgo 3.0
import Qt.labs.settings 1.0

Item {

    property alias dispatcher: logicConnection.target

    signal listingsReceived

    readonly property var listings: _.createListingsModel(_.listings)
    readonly property alias numTotalListings: _.numTotalListings
    readonly property int numListings: _.listings.length
    readonly property bool loading: client.loading
    readonly property var favoriteListings: _.createListingsModel(_.favoriteListingsValues, true)

    Client {
        id: client
    }

    Connections {
        id: logicConnection

        onSearchListings: {
            client.search(searchText, _.responseCallback)
        }

        onLoadNextPage: {
            client.repeatForPage(_.currentPage + 1, _.responseCallback)
        }

        onToggleFavorite: {
            var listingDataStr = JSON.stringify(listingData)
            var index = _.favoriteListingsValues.indexOf(listingDataStr)

            if(index < 0) {
                console.debug("Listing added")
                _.favoriteListingsValues.push(listingDataStr)
            } else {
                console.debug("Listing removed")
                _.favoriteListingsValues.splice(index, 1)
            }
            _.favoriteListingsValuesChanged()
        }
    }

    function isFavorite(listingData) {
        return _.favoriteListingsValues.indexOf(JSON.stringify(listingData)) >= 0
    }

    Settings {
        property string favoriteListingsValue: JSON.stringify(_.favoriteListingsValues)
        Component.onCompleted: {
            _.favoriteListingsValues = favoriteListingsValue && JSON.parse(favoriteListingsValue) || []
        }
    }

    Item {
        id: _

        readonly property var successCodes: ["100", "101", "110"]
        readonly property var ambiguousCodes: ["200", "202"]
        property var locations: []
        property var listings: []
        property int numTotalListings: []
        property int currentPage: 1
        property var favoriteListingsValues: []

        function responseCallback(obj){
            var response = obj.response
            var code = response.application_response_code
            console.debug("Server returned app code: ", code)

            if(successCodes.indexOf(code) >= 0)
            {
                //found locations
                currentPage = parseInt(response.page)
                listings = listings.concat(response.listings)
                numTotalListings = response.total_results || 0
                listingsReceived()
            } else if(ambiguousCodes.indexOf(code) >= 0)
            {
                locations = response.locations
            } else if(code === "210")
            {
                locations = []
            } else
            {
                locations = []
            }
        }

        function createListingsModel (source, parseValues) {
            return source.map(function(data){
                if(parseValues)
                {
                    data = JSON.parse(data)
                }
                return {
                    text: data.price_formatted,
                    datailText: data.title,
                    image: data.thumb_url,
                    model: data
                }
            })
        }
    }

}
