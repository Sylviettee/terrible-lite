<% 
local lev = ldoc.level or 2
local lev1,lev2 = ('#'):rep(lev),('#'):rep(lev+1)
local iter = ldoc.modules.iter
local no_spaces = ldoc.no_spaces
local display_name = ldoc.display_name 
local show_return = not ldoc.no_return_or_parms
local show_parms = show_return

local function M(txt, item)
  return ldoc.markup(txt, item, ldoc.plain)
end
if ldoc.body then %>
<%- ldoc.body %>
<%
elseif module then
%>
# <%- ldoc.module_typename(module) %> `<%- module.name %>`
<%- M(module.summary, module) %>
<%- M(module.description, module) %>
<% if module.tags.include then %>
<%- M(ldoc.include_file(module.tags.include)) %>
<% end %>
<% if module.see then %>
## See also
<% for see in iter(module.see) do %>
* [<%- see.label %>](<%- ldoc.href(see) %>)
<% end %>
<% end %>
<% if module.usage then %>
## Usage
<% for usage in iter(module.usage) do%>
<%- usage %>
<% end %>
<% end %>
<% if module.info then %>
## Info
<% for tag, value in module.info:iter() do %>
* **<%- tag %>**: <%- M(value, module) %> 
<% end %>
<% end %>
<% if not ldoc.no_summary then %>
<% for kind, items in module.kinds() do %>
### [<%- no_spaces(kind) %>](#<%- kind %>)
| Property | Description |
| -------- | ----------- |<% for item in items() do %>
| <%- display_name(item) %> | <%= M(item.summary, item):gsub('\n', ' ') %> |<% end %>
<% end %>
<% end %>
<%
  for kind, items in module.kinds() do
    local kitem = module.kinds:get_item(kind)
%>
## [<%- kind %>](#<%- no_spaces(kind) %>)
<%
    if kitem then
%>
<%- lev1 %> <%- ldoc.descript(kitem) %>
<% if kitem.usage then %>
#### Usage
```lua
<%- kitem.usage[1] %>
```
<% end %>
<%
    end

    for item in items() do
%>
<%- lev2 %> [<%- display_name(item) %>](#<%- item.name %>) <%- ldoc.is_file_prettified[item.module.file.filename] and '([Source](<%- ' .. ldoc.source_ref(item) .. ' %>))' or '' %>
<%- ldoc.descript(item) %>

<% if show_parms and item.params and #item.params > 0 then %>
<% local subnames = module.kinds:type_of(item).subnames %>
| <%- subnames or 'Property' %> | Type | Optional | Default | Description |
| --------------- | ---- | -------- | ------- | ----------- |
<% for parm in iter(item.params) do 
    local param,sublist = item:subparam(parm)
  %><% for p in iter(param) do
      local name, tp, def = item:display_name_of(p), 
      ldoc.typename(item:type_of_param(p)), 
      item:default_of_param(p)
%>| <%- name %> | <%- tp %> | <%- def and '☑️' or '❌'%> | <%- (def == true and '`none`') or (def and '`' .. def .. '`') or '`none`' %> | <%- M(item.params.map[p], item):gsub('\n', '  ') %> |<% end %>
<% end %>

<% end %>

<% if show_return and item.retgroups then 
local groups = item.retgroups

local returns = ''

for i, group in ldoc.ipairs(groups) do
  for r in group:iter() do
    local type, ctypes = item:return_type(r)
    local rt = ldoc.typename(type)

    returns = returns .. rt .. ' ' .. M(r.text, item)

    if ctypes then
      for c in ctypes:iter() do
        returns = returns .. ' ' .. c.name .. ' ' .. ldoc.typename(c.type) .. ' ' .. ' ' .. M(c.comment, item)
      end
    end
  end
end

returns = returns:sub(0, #returns-2)
%>
**Returns:** <%- returns:gsub('\n\n', ', ') %>

<% if show_return and item.raise then %>
**Raises:** <%- M(item.raise, item) %>
<% end %>

<% end %>

<%
if item.see then      
%>   
**See also:**
<% for see in iter(item.see) do %>
* [<%- see.label %>](<%- ldoc.href(see) %>)
<% end %>
<% end %>

<% if item.usage then %>
**Usage: **
<% for usage in iter(item.usage) do %>
```lua
<%- usage %>
```
<% end %>
<% end %>

<%
    end
  end
%>
<% else %>

<% if ldoc.description then %>
## <%= M(ldoc.description, nil) %>
<% end %>

<% if ldoc.full_description then %>
## <%= M(ldoc.full_description, nil) %></h2>
<% end %>

<% for kind, mods in ldoc.kinds() do %>
### <%= kind %>

  <% kind = kind:lower() %>
| Module | Description |
| ------ | ----------- |
<% for m in mods() do %>| [<%- m.name %>](<%= no_spaces(kind) %>/<%- m.name %><%= m.name:sub(#m.name - 2, #m.name) == '.md' and '' or '.md' %>) | <%- M(ldoc.strip_header(m.summary), m) %>
<% end %>
<% end %>

<% end %>