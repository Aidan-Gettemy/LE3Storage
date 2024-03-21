function stat = savesmalltbl(tableID,vector)
  datat = readtable(tableID);
  names = datat.Properties.VariableNames;
  smallT = table();
  for i = 1:numel(vector)
    x = datat(:,x_value);
    x = x.Variables;
    smallT.names(i) = x;
  end
  
end
