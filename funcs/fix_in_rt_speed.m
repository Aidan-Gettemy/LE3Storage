function rtspeed = fix_in_rt_speed(windspeed)
  y = readmatrix("rtpoints.txt");
  x = 3:26;
  rtspeed = min(spline(x,y,windspeed),12.1);
end
