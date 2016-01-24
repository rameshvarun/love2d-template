# Mixins
Mixins can be used to share behavior between unrelated classes, as a sort of horizontal inheritance. See the [middleclass wiki](https://github.com/kikito/middleclass/wiki/Mixins) for specifics. For entities, you should first consider Components, since multiple instances of the same Component can be added in to an object, whereas a mixin can only be "added" in once.
