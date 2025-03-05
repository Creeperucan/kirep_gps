local versionURL = 'https://raw.githubusercontent.com/Creeperucan/kirep_gps/refs/heads/main/fxmanifest.lua' -- GitHub'daki fxmanifest.lua dosyanızın URL'si
local currentVersion = '1.0.1'

PerformHttpRequest(versionURL, function(errorCode, resultData, resultHeaders)
    if errorCode == 200 then
        local latestVersion
        for line in resultData:gmatch("[^\r\n]+") do
            if line:match("^version%s+'(.-)'") then
                latestVersion = line:match("^version%s+'(.-)'")
                break
            end
        end
        
        if latestVersion then
            if latestVersion ~= currentVersion then
                print('^3An update is available for kirep_gps (current version: ' .. currentVersion .. ')^0')
                print('^3https://github.com/Creeperucan/kirep_gps^0')
            else
                print('^2The script is up to date!^0')
            end
        else
            print('^1Could not retrieve version information from the manifest!^0')
        end
    else
        print('^1GitHub version information could not be retrieved!^0')
    end
end, 'GET', '', {})
