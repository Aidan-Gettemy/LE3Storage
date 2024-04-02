function pitch = fix_init_bldptch(windspeed)
  a = [0.0002	-0.0165	0.6367	-12.2414	118.6335	-458.0461];
  pitch=max(polyval(a,windspeed),0);
end
