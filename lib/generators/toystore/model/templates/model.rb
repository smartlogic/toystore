class <%= class_name %><%= " < #{options[:parent].classify}" if options[:parent] %>
<%- unless options[:parent] -%>
  include Toy::Store

  # replace this with whatever adapter you want
  adapter :memory, {}
<%- end -%>

<%- attributes.each do |attribute| -%>
  attribute :<%= attribute.name %>, <%= attribute.type_class %>
<%- end -%>

<%- if options[:timestamps] -%>
  timestamps
<%- end -%>
end
