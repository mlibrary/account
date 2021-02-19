local arr = std.parseJson(importstr './env.json');
{
  _functions::{
    envVar(key,value): {
      name: key,
      value: value
    },
    secret(name, key): {
      name: key,
      valueFrom: {
        secretKeyRef: {
          key: key,
          name: name,
        },
      }
    },
  },
  _envVar::[
   if x.kind == 'envVar' then
     $._functions.envVar(x.key, x.value) 
   else 
     $._functions.secret(x.name, x.key),
   for x in arr 
  ],
}
