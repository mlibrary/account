local arr = std.parseJson(importstr './env.json');
{
  _functions::{
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
     $._functions.secret(x.name, x.key),
   for x in arr 
  ],
}
