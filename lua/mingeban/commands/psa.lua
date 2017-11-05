if SERVER then
    util.AddNetworkString("message")
    local function send(msg,ply)
        net.Start("message",false)
        net.WriteString(msg)
        net.Send(ply)
    end
    
    local psa = mingeban.CreateCommand("psa", function(caller,line)
    	for k,v in pairs(player.GetAll()) do
    		send(line,v)
	end
    end)
    
    psa:SetHideChat(true)
    mingeban.GetRank("admin"):AddPermission("command.psa")
end

if CLIENT then
    local function CreateFont()
        surface.CreateFont( "Roboto", {
        font = "Roboto",
        extended = true,
        size = 35,
        weight = 200,
        antialias = true
        } )
    end
    CreateFont() -- create font twice just in case
    net.Receive( "message", function(len)
        local time = CurTime()
        local num = 35
        local psamessage = net.ReadString()
		surface.PlaySound("buttons/button3.wav")
        
        local strlen = string.len(psamessage)
        local biggershit = (strlen > 107)
        local x = biggershit and ScrW() or ScrW()/2
        
        hook.Add( "HUDPaint", "drawPSA", function()
            local timeex = (SysTime()-time)
            if (timeex > 5) then
                timeex =- timeex
                timeex = timeex + 10
            end
            local textpos = math.Clamp(math.EaseInOut((timeex*50)*-1,num,0),0,num+7)
            local bgpos = math.Clamp(math.EaseInOut((timeex*50)*-1,num,0),-16,num)
            surface.SetDrawColor(Color( 50, 50, 50, 255 ))
            surface.DrawRect(0, bgpos-40, ScrW(), 55)
            
            if biggershit then
            	x = x - 1
            end
            
            draw.Text({
	            text = psamessage,
	            font = "Roboto",
	            pos = { x, textpos },
	            xalign = biggershit and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER,
	            yalign = TEXT_ALIGN_BOTTOM,
	            color = Color(255,255,255,255)
            })
					
	    surface.DrawRect(0, bgpos-40, 80, 55)
            surface.SetDrawColor(Color( 255, 255, 255, 255 ))
            surface.DrawLine(80,bgpos-30, 80, bgpos+7.5)
            
            draw.Text({
	            text = "PSA",
	            font = "Roboto",
	            pos = { 15, textpos },
	            xalign = TEXT_ALIGN_LEFT,
	            yalign = TEXT_ALIGN_BOTTOM,
	            color = Color(255,255,255,255)
            })
        end)
    end )
end
