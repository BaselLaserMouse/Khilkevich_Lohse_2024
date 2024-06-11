function h=mydialog(varargin)
%
%    Copyright 2003  Brian Blais
%    Plasticity: A Synaptic Modification Simulation Environment
%
%    This file is part of Plasticity, and is free software; you can
%    redistribute it and/or modify it under the terms of the GNU General Public
%    License as published by the Free Software Foundation; either version 2 of
%    the License, or (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program; if not, write to the Free Software
%    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
%
  
hfig=dialog('resize','on',varargin{:});
set(hfig,'units','points');

sz_big=get(hfig,'position'); sz_big=sz_big(3:4);
%setuprop(hfig,'cancel',0);

% do the buttons
sz_button=[7 1.5]; % approximate,
      
% cancel
pos=[10 10];

h=uicontrol(hfig,'Style', 'pushbutton',...
    'String', 'Cancel',...
    'units','points',...
    'position',[pos sz_button],...
    'fontsize',10,...
    'horizontalalignment','center',...
    'userdata',hfig,...
	    'tag','cancel_button',...
    'Callback','setuprop(gcf,''cancel'',1);  uiresume;');

ex=get(h,'extent'); ex=ex(3:4); 
sz_button=ex*1.2; 
set(h,'position',[pos sz_button]);

% ok
pos(1)=[sz_big(1)-sz_button(1)-pos(1)];

uicontrol(hfig,'Style', 'pushbutton',...
    'String', 'Ok',...
    'units','points',...
    'position',[pos sz_button],...
    'fontsize',10,...
    'horizontalalignment','center',...
	    'tag','ok_button',...
    'Callback','uiresume;');


if (nargout>0)
  h=hfig;
end
      
