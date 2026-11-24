import QtQuick
import Quickshell
import Quickshell.Io

// Keeps the Millennium "Omarchy" Steam theme in sync with the active Omarchy
// theme. Omarchy writes theme.generation once a theme switch has been applied,
// so a change to that file is the signal to regenerate. Generation takes well
// under a second; the theme's own script then live-reloads open Steam windows.
Item {
  id: root

  property var shell: null

  readonly property string stateHome: Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")
  readonly property string generator: Qt.resolvedUrl("bin/steam-theme-sync").toString().replace(/^file:\/\//, "")
  property bool pending: false

  function regenerate() {
    if (proc.running) {
      pending = true
      return
    }
    pending = false
    proc.running = true
  }

  Component.onCompleted: regenerate()

  FileView {
    path: root.stateHome + "/omarchy/current/theme.generation"
    watchChanges: true
    printErrors: false
    onFileChanged: debounce.restart()
  }

  // theme-set rewrites several files in a burst; wait for it to settle.
  Timer {
    id: debounce
    interval: 400
    onTriggered: root.regenerate()
  }

  Process {
    id: proc
    command: ["python3", "-I", root.generator]
    stdout: StdioCollector { waitForEnd: true }
    stderr: StdioCollector {
      waitForEnd: true
      onStreamFinished: if (text.trim() !== "") console.log("steam-theme-sync: " + text.trim().slice(0, 300))
    }
    onRunningChanged: if (!running && root.pending) root.regenerate()
  }
}
