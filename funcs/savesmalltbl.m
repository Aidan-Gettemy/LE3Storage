function stat = savesmalltbl(tableID,saveID,vector)
  datat = readtable(tableID);
  names = datat.Properties.VariableNames;
  savednames = names(vector);
  x = datat(:,vector(1));
  x = x.Variables;
  M = zeros(numel(x),numel(vector));
  for i = 1:numel(vector)
    x = datat(:,vector(i));
    x = x.Variables;
    M(:,i) = x;
  end
  smallT = array2table(M);
  smallT.Properties.VariableNames = savednames;
  writetable(smallT,saveID)
  stat = "okay";
end
