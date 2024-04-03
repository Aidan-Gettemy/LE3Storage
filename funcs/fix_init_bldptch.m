function pitch = fix_init_bldptch(windspeed)
  y = readmatrix("bldptchpoints.txt");
  x = 3:26;
  pitch = spline(x,y,windspeed);
end
