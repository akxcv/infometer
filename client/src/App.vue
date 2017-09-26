<template>
  <form @submit.prevent="submit">
    <div class="text">
      <div class="prompt">{{ prompt }}</div>
      <div :class="`percentage ${percentageColor}`" v-if="measured">{{ percentage }}</div>
    </div>
    <input autofocus type="text" v-model="message" @keydown="keydown" />
    <button type="submit" :disabled="loading || message.trim() === ''">
      {{ loading ? 'Loading...' : 'Measure' }}
    </button>
  </form>
</template>

<script>
  const UP_ARROW = 38
  const DOWN_ARROW = 40

  export default {
    data () {
      return {
        message: '',
        percentage: null,
        prompt: 'Measure anything',
        measured: false,
        history: [],
        historyIndex: -1,
        loading: false,
      }
    },
    computed: {
      percentageColor () {
        if (this.percentage >= 90) return 'red'
        if (this.percentage >= 75) return 'yellow'
        return 'blue'
      },
    },
    methods: {
      submit () {
        this.loading = true
        fetch(`${__CONFIG__.backendUrl}/api/percentage`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            message: this.message.trim(),
          }),
        }).then(response => response.json()).then(json => {
          this.measured = true
          this.percentage = Number(json.percentage)
          this.prompt = this.message
          this.history.unshift(this.message)
          this.message = ''
          this.historyIndex = -1
        }).catch(() => {
          /* display error */
        })
          .then(() => {
            this.loading = false
          })
      },
      keydown (e) {
        if (e.keyCode === UP_ARROW && this.history.length - 1 > this.historyIndex) {
          this.historyIndex += 1
          this.message = this.history[this.historyIndex]
          e.preventDefault()
        } else if (e.keyCode === DOWN_ARROW && this.historyIndex > -1) {
          this.historyIndex -= 1
          this.message = this.history[this.historyIndex] || ''
          e.preventDefault()
        }
      },
    },
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
    width: 100px;
  }

  button:disabled {
    background-color: #aaa;
    border-color: #aaa;
    cursor: not-allowed;
  }
</style>
