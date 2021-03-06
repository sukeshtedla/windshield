module Utils exposing (..)

import Model exposing (..)
import Date.Extra.Format as DateFormat
import Date.Extra.Config.Config_en_us as DateConfig
import Date.Distance as Distance
import FormatNumber exposing (format)
import FormatNumber.Locales exposing (usLocale)
import Time
import Date


genesisTime : Time.Time
genesisTime =
    1527897600000


calcTimeDiffProd : Time.Time -> Time.Time -> String
calcTimeDiffProd bpTime nowTime =
    if bpTime < genesisTime then
        "No Data"
    else
        calcTimeDiff bpTime nowTime


calcTimeDiff : Time.Time -> Time.Time -> String
calcTimeDiff timeOld timeNew =
    let
        defaultConfig =
            Distance.defaultConfig

        config =
            { defaultConfig | includeSeconds = True }

        inWords =
            config
                |> Distance.inWordsWithConfig

        dateOld =
            Date.fromTime timeOld

        dateNew =
            Date.fromTime timeNew
    in
        inWords dateOld dateNew


newErrorNotification : Model -> String -> Bool -> ( Model, Cmd msg )
newErrorNotification model error unload =
    let
        notifications =
            Notification (Error error)
                model.currentTime
                ("err" ++ toString model.currentTime)
                :: model.notifications

        isLoading =
            if unload then
                model.isLoading - 1
            else
                model.isLoading
    in
        ( { model | notifications = notifications, isLoading = isLoading }
        , Cmd.none
        )


formatPercentage : Float -> String
formatPercentage num =
    format usLocale (num * 100) ++ "%"


formatTime : Time.Time -> String
formatTime time =
    if time > 0 then
        time
            |> Date.fromTime
            |> DateFormat.format DateConfig.config
                "%m/%d/%Y %H:%M:%S"
    else
        "--"


reversedComparison : comparable -> comparable -> Order
reversedComparison a b =
    case compare a b of
        LT ->
            GT

        EQ ->
            EQ

        GT ->
            LT


nodeAddressLink : Node -> String
nodeAddressLink node =
    let
        prefix =
            if node.isSsl then
                "https://"
            else
                "http://"
    in
        prefix ++ node.ip ++ ":" ++ toString node.addrPort ++ "/v1/chain/get_info"


nodeAddress : Node -> String
nodeAddress node =
    node.ip ++ ":" ++ toString node.addrPort


nodeTypeTxt : NodeType -> String
nodeTypeTxt nodeType =
    case nodeType of
        BlockProducer ->
            "BP"

        FullNode ->
            "FN"

        ExternalBlockProducer ->
            "EBP"
