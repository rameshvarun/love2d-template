# Components
Components are not required.

## Motivation
Components exist to allow for easier code refactoring / reuse. I initially considered Mixins.
However, mixins only let a specific behavior be mixed in once. This prevents a lot of useful cases,
such as an object that consists of multiple image components. Instead, mixins are now used as a sort of multiple-inheritance.
