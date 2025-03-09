Config = {
    General = {
        updateInterval = 500,           -- 1000 = 1 second (We do not recommend setting it to 0.)
        playerBlip = true,              -- If set to 'true', the player's own blip will be hidden.
        itemName = 'gps',               -- Item Name
        lang = 'en-US',                 -- Language
        debug = false,                  -- Debug Mode
    },

    Noification = {
        backgroundColor = '#141517',    -- Background Color (HEX)
        descriptionColor = '#909296',   -- Description Color (HEX)
        titleColor = '#C1C2C5',         -- Title Color (HEX)
        showDuration = false,           -- If set to true, it will display how long the notification will stay under the notification.
        position = 'top',               -- Notification Position (top, top-right, top-left, bottom, bottom-right, bottom-lest, center, center-right, center-left)
        iconAnimation = nil,            -- Notification Icon Animation (spin, spinPulse, spinReverse, pulse, beat, fade, beatFade, bounce, shake, nil = none)

        deniedColor = '#C53030',        -- Denied Color (HEX)
        successColor = '#00d945',       -- Success Color (HEX)

        deniedIcon = 'ban',             -- https://fontawesome.com/icons
        successIcon = 'circle-check'    -- https://fontawesome.com/icons
    },

    Webhook = {
        URL = 'WEBHOOK_URL_HERE_REQUIRED',
        imageURL = 'IMAGE_URL_HERE_REQUIRED',
        serverName = 'Server Name',     -- Webhook Bot Name
        enabled = false,                -- Set it to 'true' to activate the webhook.
        noJobLog = false,               -- If set to 'true', a notification will be sent when people without the required profession use it.

        successColor = 47678,           -- Decimal Color (https://convertingcolors.com/hex-color-FFFFFF.html)
        deniedColor = 13703966,         -- Decimal Color (https://convertingcolors.com/hex-color-FFFFFF.html)
        noJobColor = 13703966           -- Decimal Color (https://convertingcolors.com/hex-color-FFFFFF.html)
    },
}

/*


 _     _
| | __(_) _ __   ___  _ __
| |/ /| || '__| / _ \| '_ \
|   < | || |   |  __/| |_) |
|_|\_\|_||_|    \___|| .__/
                     |_|


Support: htttps://discord.gg/3TCCX49gsQ
For Blip Information: https://docs.fivem.net/docs/game-references/blips/

*/