function pitch = fix_init_bldptch(windspeed)
  a = [8.0206e-06	-0.0011	0.0585	-1.7942	32.7361	-355.5472	2.1315e+03	-5.4479e+03]*1000;
  pitch=max(polyval(a,windspeed),0);
end
