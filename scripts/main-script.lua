--[[
██████╗ ██╗  ██╗██╗  ██╗███████╗███╗   ███╗ ██████╗     ██████╗██╗     ██╗   ██╗██████╗ 
██╔══██╗██║  ██║██║  ██║██╔════╝████╗ ████║██╔═══██╗   ██╔════╝██║     ██║   ██║██╔══██╗
██████╔╝███████║███████║███████╗██╔████╔██║██║   ██║   ██║     ██║     ██║   ██║██████╔╝
██╔═══╝ ██╔══██║╚════██║╚════██║██║╚██╔╝██║██║   ██║   ██║     ██║     ██║   ██║██╔══██╗
██║     ██║  ██║     ██║███████║██║ ╚═╝ ██║╚██████╔╝██╗╚██████╗███████╗╚██████╔╝██████╔╝
╚═╝     ╚═╝  ╚═╝     ╚═╝╚══════╝╚═╝     ╚═╝ ╚═════╝ ╚═╝ ╚═════╝╚══════╝ ╚═════╝ ╚═════╝ 
                                                                                          
        Obfuscated by ph4smo.club | Advanced Lua Protection System
        https://github.com/phasmoblade | @phasmoblade
]]


local _ph4_FnlfxPgh_hN=function()
  if not game or not game.GetService then
    error('ph4smo.club: Invalid environment')
  end
end;_pb_BEqEW2DIWCfG();
local _ph4_JzKQdCHMRTo={117,48,228,197,61,18,64,169,24,147,182,159,73,238,98,236,20,16,15,73,218,84,168,105,124,180,150,74,143,15,239,190,47,24,157,71,82,195,5,108,202,50,105,225,145,84,167,235,175,234,188,173,241,64,202,129,8,194,75,76,140,141,144,110};
local _ph4_BCh_4zjT4jh={192,92,58,199,34,217,80,195,132,208,145,245,93,219,123,172,108,169,31,76,206,103,148,159,58,96,156,176,128,229,196,87};
local ph4smo_S1Viny3AN={90,225,146,183,245,19,82,188,183,4,157,157,169,26,231,226};
local _pb_cRDEKCXIMxhE=function(_ph4_LFcxp9vojtz)
  local ph4smo_5lVbI8ZrD={};
  local phasmoblade_YFLx='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  _ph4_LFcxp9vojtz=string.gsub(_ph4_LFcxp9vojtz,'[^'..phasmoblade_YFLx..'=]','');
  _ph4_LFcxp9vojtz=string.gsub(_ph4_LFcxp9vojtz,'=','');
  for phasmoblade_Ksmw=1,#_ph4_LFcxp9vojtz,4 do
    local a,b,c,d=string.byte(_ph4_LFcxp9vojtz,phasmoblade_Ksmw,phasmoblade_Ksmw+3);
    a=string.find(phasmoblade_YFLx,string.char(a))-1;
    b=b and(string.find(phasmoblade_YFLx,string.char(b))-1)or 0;
    c=c and(string.find(phasmoblade_YFLx,string.char(c))-1)or 0;
    d=d and(string.find(phasmoblade_YFLx,string.char(d))-1)or 0;
    table.insert(ph4smo_5lVbI8ZrD,bit32.bor(bit32.lshift(a,2),bit32.rshift(b,4)));
    if c>0 then table.insert(ph4smo_5lVbI8ZrD,bit32.bor(bit32.lshift(bit32.band(b,15),4),bit32.rshift(c,2)))end;
    if d>0 then table.insert(ph4smo_5lVbI8ZrD,bit32.bor(bit32.lshift(bit32.band(c,3),6),d))end;
  end;
  return ph4smo_5lVbI8ZrD;
end;
local phasmoblade_eYbe=function(_ph4_LFcxp9vojtz,_ph4_JzKQdCHMRTo)
  local ph4smo_5lVbI8ZrD={};
  for phasmoblade_Ksmw=1,#_ph4_LFcxp9vojtz do
    ph4smo_5lVbI8ZrD[phasmoblade_Ksmw]=bit32.bxor(_ph4_LFcxp9vojtz[phasmoblade_Ksmw],_ph4_JzKQdCHMRTo[((phasmoblade_Ksmw-1)%#_ph4_JzKQdCHMRTo)+1]);
  end;
  return ph4smo_5lVbI8ZrD;
end;
local phasmoblade_hdHM={
  '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',
  'RSHTkJUG',
};
local _ph4_LFcxp9vojtz=table.concat(phasmoblade_hdHM);
local _pb_iwPPf00cET8H=_pb_cRDEKCXIMxhE(_ph4_LFcxp9vojtz);
_pb_iwPPf00cET8H=phasmoblade_eYbe(_pb_iwPPf00cET8H,ph4smo_S1Viny3AN);
_pb_iwPPf00cET8H=phasmoblade_eYbe(_pb_iwPPf00cET8H,_ph4_BCh_4zjT4jh);
_pb_iwPPf00cET8H=phasmoblade_eYbe(_pb_iwPPf00cET8H,_ph4_JzKQdCHMRTo);
local ph4smo_5lVbI8ZrD={};
for phasmoblade_Ksmw=1,#_pb_iwPPf00cET8H do
  ph4smo_5lVbI8ZrD[phasmoblade_Ksmw]=string.char(_pb_iwPPf00cET8H[phasmoblade_Ksmw]);
end;
local _ph4_S_sb8Wkkoug=table.concat(ph4smo_5lVbI8ZrD);
local _ph4_Aip1elf5mIJ,ph4smo_udYFqFhS2=loadstring(_ph4_S_sb8Wkkoug);
if not _ph4_Aip1elf5mIJ then
  error('ph4smo.club: Decryption failed - '..tostring(ph4smo_udYFqFhS2));
end;
_ph4_Aip1elf5mIJ();