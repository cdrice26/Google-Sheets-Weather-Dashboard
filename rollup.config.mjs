import nodeResolve from '@rollup/plugin-node-resolve';
import removeExportsPlugin from './removeExportsPlugin.mjs';

export default {
  input: 'lib/es6/src/Code.res.mjs',
  output: {
    file: 'dist/Code.res.gs',
    format: 'es'
  },
  plugins: [nodeResolve(), removeExportsPlugin()]
};
