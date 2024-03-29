function pitch = fix_init_bldptch(windspeed)
  a=[-0.001287,    0.1013,   -2.968,   39.65, -193];
  pitch=max(polyval(a,windspeed),0);
end
