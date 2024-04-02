function rtspeed = fix_in_rt_speed(windspeed)
  a = [-0.0011	0.0344	-0.4150	2.4330	-6.6729	13.7661];
  b = [0.3788	-12.1417	129.9142	-452.2309];
  c = [0.0012	-0.0234	12.1697];
  if windspeed<10.25
    rtspeed = polyval(a,windspeed);
  else 
      if windspeed<11.4
        rtspeed = polyval(b,windspeed);
      else
        rtspeed = polyval(c,windspeed);
      end
  end
end
