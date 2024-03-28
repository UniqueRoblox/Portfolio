from kivy.app import App
from kivy.modules import inspector  # For inspection.
from kivy.core.window import Window  # For inspection.
from kivy.lang import Builder
from kivy.uix.tabbedpanel import TabbedPanel


class SettingsApp(App):
    def build(self):
        inspector.create_inspector(Window, self)  # For inspection (press control-e to toggle).


if __name__ == '__main__':
    app = SettingsApp()
    app.run()
