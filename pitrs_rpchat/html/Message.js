window.Message = {
  template: '#message_template',
  props: ['templates', 'multiline', 'args', 'color', 'template', 'templateId', 'visible'],
  computed: {
    textEscaped() {
      if (this.template) {
        return this.template.replace(/{(\d+)}/g, (match, index) => {
          return this.args[index] || match;
        });
      } else if (this.args && this.args.length > 0) {
        return this.args.join(' ');
      }
      return '';
    }
  }
};