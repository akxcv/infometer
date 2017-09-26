<template>
  <form @submit="submit">
    <div class="text">
      <div class="prompt">{{ prompt }}</div>
      <div :class="`percentage ${percentageColor}`" v-if="measured">{{ percentage }}</div>
    </div>
    <input autofocus type="text" v-model="message" />
    <button type="submit">Measure</button>
  </form>
</template>

<script>
  export default {
    data: function () {
      return {
        message: '',
        percentage: null,
        prompt: 'Measure anything',
        measured: false,
      }
    },
    computed: {
      percentageColor: function () {
        if (this.percentage >= 90) return 'red'
        if (this.percentage >= 75) return 'yellow'
        return 'blue'
      }
    },
    methods: {
      submit (e) {
        e.preventDefault()
        fetch(`${__CONFIG__.backendUrl}/api/percentage`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            message: this.message,
          }),
        }).then(response => response.json()).then(json => {
          this.measured = true
          this.percentage = Number(json.percentage)
          this.prompt = this.message
          this.message = ''
        })
      }
    }
  }
</script>

<style>
  form {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
  }

  .text {
    text-align: center;
    margin-bottom: 15px;
  }

  .percentage {
    font-size: 50px;
    color: cornflowerblue;
  }

  .prompt {
    font-size: 25px;
    max-width: 250px;
    margin: 0 auto;
  }

  .percentage:after {
    content: '%';
  }

  .percentage.red {
    color: crimson;
  }

  .percentage.yellow {
    color: darkgoldenrod;
  }

  input {
    border: 2px solid cornflowerblue;
    border-radius: 9px;
    padding: 6px 9px;
    outline: none;
    font-size: 16px;
  }

  button {
    cursor: pointer;
    background-color: cornflowerblue;
    border: 2px solid cornflowerblue;
    border-radius: 9px;
    padding: 6px 9px;
    color: white;
    font-size: 16px;
  }
</style>
