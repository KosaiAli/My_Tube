import sublime
import sublime_plugin


class SaveAndFormatDocumentCommand(sublime_plugin.TextCommand):
    def run(self, edit):
        # Save the document
        self.view.run_command("save")

        # Format the document using LSP
        self.view.run_command("lsp_format_document")