<template>
  <div id="app">
    <p>{{ message }}</p>
  </div>
</template>

<script>
export default {
  data: function () {
    return {
      message: "Hello Framework!"
    }
  }
}
</script>

<style lang="scss">
p {
  font-size: 2rem;
  text-align: center;
}
</style>
