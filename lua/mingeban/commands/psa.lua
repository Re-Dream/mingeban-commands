if SERVER then
    util.AddNetworkString("message")
    local function send(msg,ply)
        net.Start("message",false)
        net.WriteString(msg)
        net.Send(ply)
    end
    
    mingeban.CreateCommand("psa", function(caller,line)
    	for k,v in pairs(player.GetAll()) do
    		send(line,v)
		end
    end)
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
            local timeex = (CurTime()-time)
            if (timeex > 5) then
                timeex =- timeex
                timeex = timeex + 10
            end
            local textpos = math.Clamp(math.EaseInOut((timeex*50)*-1,num,0),0,num+7)
            local bgpos = math.Clamp(math.EaseInOut((timeex*50)*-1,num,0),-16,num)
            surface.SetDrawColor(Color( 50, 50, 50, 255 ))
            surface.DrawRect(0, bgpos-40, ScrW(), 55)
            
            if biggershit then
            	x = x - strlen / 107 * 2.5
        	end
            
            draw.Text({
	            text = psamessage,
	            font = "Roboto",
	            pos = { x, textpos },
	            xalign = biggershit and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER,
	            yalign = TEXT_ALIGN_BOTTOM,
	            color = Color(255,255,255,255)
            })
        end)
    end )
end
