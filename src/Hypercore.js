import Hypercore from 'hypercore';
import RAM from 'random-access-memory';

// start()

// async function start () {
//   console.log("Hypercore.js")
//   const core = new Hypercore(RAM)
//   await core.append(['Hello', 'World'])
//   console.log(core)
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

export const hypercore_ = async (storage, options) => {
  const optionsJS = optionsFromPS(options);
  if (storage.constructor.name === "RAM") {
    return new Hypercore(RAM, optionsJS);
  } else if (storage.constructor.name === "RAF") {
    return new Hypercore(storage.value0, optionsJS);
  }
};

export const hypercoreWithKey_ = async (storage, key, options) => (
  onError,
  onSuccess
) => {
  if (storage.constructor.name === "RAM") {
    return new Hypercore(RAM, key, options);
  } else if (storage.constructor.name === "RAF") {
    return new Hypercore(storage.value0, key, options);
  }
};

export const append_ = async (data, feed) => await feed.append(data);

export const get_ = async (index, feed) => await feed.get(index);
