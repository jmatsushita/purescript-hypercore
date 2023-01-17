import Hypercore from "hypercore";
import RAM from "random-access-memory";
import RAI from "@storyboard-fm/stochastic-access-idb";

// start()

// async function start () {
//   console.log("Hypercore.js")
//   const core = new Hypercore(RAM)
//   await core.append(['Hello', 'World'])
//   console.log(core)
//   const info = await core.info()
//   console.log("info", info)
//   await core.close()
//   console.log("------------")
// }

const optionsFromPS = (options) => {
  const valueEncoding =
    options.valueEncoding === "$$JSON"
      ? "json"
      : options.valueEncoding === "BINARY"
      ? "binary"
      : options.valueEncoding === "UTF8"
      ? "utf8"
      : "json";
  return Object.assign(options, {
    valueEncoding,
  });
};

export const hypercoreRAMImpl = async (options) => {
  const optionsJS = optionsFromPS(options);
  const ram = () => new RAM();
  const core = new Hypercore(ram, optionsJS);
  await core.ready();
  return core;
};

export const hypercoreRAIImpl = async (options) => {
  const optionsJS = optionsFromPS(options);
  const core = new Hypercore(RAI.storage(), optionsJS);
  await core.ready();
  return core;
};

export const hypercoreRAFImpl = async (filepath, options) => {
  const optionsJS = optionsFromPS(options);
  console.log("filepath", filepath)
  const core = new Hypercore(filepath, optionsJS);
  await core.ready();
  return core;
};

export const hypercoreWithKey_ =
  async (storage, key, options) => (onError, onSuccess) => {
    throw new Error("hypercoreWithKey_ not implemented");
    // if (storage.constructor.name === "RAM") {
    //   return new Hypercore(RAM, key, options);
    // } else if (storage.constructor.name === "RAI") {
    //   return new Hypercore(RAI.storage(), key, options);
    // } else if (storage.constructor.name === "RAF") {
    //   return new Hypercore(storage.value0, key, options);
    // }
  };

// export const append_ = async (data, core) => await core.append(data);
export const append_ = async (data, core) => {
  console.log("append.data", data);
  const { length, byteLength } = await core.append(data);
  //  console.log("byteLength", byteLength)
  return length;
};

export const get_ = async (index, core) => await core.get(index);
export const truncate_ = async (index, core) => await core.truncate(index);

export const bytes_ = async (core) => {
  // console.log("bytes_.core.info", core.info)
  // const info = core.info ? await core.info() : { byteLength: 0 };
  const info = await core.info();

  return info.byteLength;
};

// export const subscribe_ = async (handler, core) => core.on('data', handler);
export const subscribe_ = (handler, core) =>
  core.on("append", (data) => handler(data)());

export const cursor_ = (handler, core) =>
  core.on("append", (_) => handler(core.length)());
// export const cursor_ = (handler, core) => {
//   core.on('append', _ => {
//     console.log("Hypercore.append.length", core.length)
//     return handler(core.length)();
//   })
// };

export const dump_ = async (core) => {
  // read the full core
  const fullStream = core.createReadStream();

  let all = []; // allocate?
  // async iterable are not well supported :/
  for await (const data of fullStream) {
    all.push(data);
  }
  console.log("dump", all);
  return all;
};
