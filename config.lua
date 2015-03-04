if(string.sub( system.getInfo("model") ,1 ,4) == "iPad") then
        application = 
        {
                content = 
                {
                        width = 360,
                        height = 480,
                        fps = 60,
                        xAlign = "center",
                        yAlign = "center",
                        scale = "letterBox",
                        imageSuffix =
                        {
                                ["@2x"] = 1.5,
                                ["@4x"] = 3.0,
                        },
                }
        }
else
        local aspectRatio = display.pixelHeight / display.pixelWidth
        application = {
                content = {
            width = aspectRatio > 1.5 and 320 or math.ceil( 480 / aspectRatio ),
            height = aspectRatio < 1.5 and 480 or math.ceil( 320 * aspectRatio ),
                        --width = display.pixelWidth/2,
                        --height = display.pixelHeight/2, 
                        scale = "letterBox",
                        fps = 60,
                
                        --[[
                imageSuffix = {
                            ["@2x"] = 2,
                        }
                        --]]
                },

            --[[
            -- Push notifications

            notification =
            {
                iphone =
                {
                    types =
                    {
                        "badge", "sound", "alert", "newsstand"
                    }
                }
            }
            --]]    
        }
end