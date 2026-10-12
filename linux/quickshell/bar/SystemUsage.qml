import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import ".."

// Compact usage summary: CPU, RAM, CPU temperature and, while the NVIDIA GPU
// is awake, its load and temperature. Click opens btop.
MouseArea {
    id: root

    property real cpuPercent: 0
    property real memPercent: 0
    property real cpuTemp: 0
    property bool gpuAwake: false
    property real gpuPercent: 0
    property real gpuTemp: 0

    property var lastCpu: null
    property string coretempDir: ""

    // Same PCI address as `lspci` shows for the RTX 3050
    readonly property string gpuPowerFile: "/sys/bus/pci/devices/0000:01:00.0/power/runtime_status"

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight
    cursorShape: Qt.PointingHandCursor
    onClicked: Quickshell.execDetached(["wezterm", "start", "--class", "btop", "--", "btop"])

    function level(value, warn, critical) {
        return value >= critical ? Theme.red : value >= warn ? Theme.accentAlt : Theme.fg;
    }

    RowLayout {
        id: row
        spacing: 10

        BarText {
            text: `${Icons.cpu} ${Math.round(root.cpuPercent)}%`
            color: root.level(root.cpuPercent, 70, 90)
        }
        BarText {
            text: `${Icons.memory} ${Math.round(root.memPercent)}%`
            color: root.level(root.memPercent, 75, 90)
        }
        BarText {
            visible: root.cpuTemp > 0
            text: `${Icons.temperature} ${Math.round(root.cpuTemp)}°`
            color: root.level(root.cpuTemp, 75, 90)
        }
        BarText {
            visible: root.gpuAwake
            text: `${Icons.gpu} ${Math.round(root.gpuPercent)}% ${Math.round(root.gpuTemp)}°`
            color: root.level(root.gpuTemp, 75, 87)
        }
    }

    FileView { id: statFile; path: "/proc/stat" }
    FileView { id: memFile; path: "/proc/meminfo" }
    FileView { id: tempFile; path: root.coretempDir ? root.coretempDir + "/temp1_input" : "" }
    FileView { id: gpuPowerState; path: root.gpuPowerFile }

    // hwmon numbering changes between boots; find the CPU sensor by name
    Process {
        running: true
        command: ["sh", "-c", "for d in /sys/class/hwmon/*; do [ \"$(cat $d/name)\" = coretemp ] && echo $d && break; done"]
        stdout: StdioCollector { onStreamFinished: root.coretempDir = text.trim() }
    }

    // Only queried while the GPU is already awake, so it never wakes it up
    Process {
        id: gpuQuery
        command: ["nvidia-smi", "--query-gpu=utilization.gpu,temperature.gpu", "--format=csv,noheader,nounits"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(",").map(Number);
                if (parts.length === 2 && !isNaN(parts[0])) {
                    root.gpuPercent = parts[0];
                    root.gpuTemp = parts[1];
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            statFile.reload();
            memFile.reload();
            tempFile.reload();
            gpuPowerState.reload();

            // CPU: busy share of the jiffies elapsed since the last sample
            const fields = statFile.text().split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
            const idle = fields[3] + fields[4];
            const total = fields.reduce((a, b) => a + b, 0);
            if (root.lastCpu) {
                const deltaTotal = total - root.lastCpu.total;
                if (deltaTotal > 0)
                    root.cpuPercent = 100 * (1 - (idle - root.lastCpu.idle) / deltaTotal);
            }
            root.lastCpu = { idle: idle, total: total };

            const memText = memFile.text();
            const total_kb = Number((memText.match(/MemTotal:\s+(\d+)/) || [0, 0])[1]);
            const available_kb = Number((memText.match(/MemAvailable:\s+(\d+)/) || [0, 0])[1]);
            if (total_kb > 0) root.memPercent = 100 * (1 - available_kb / total_kb);

            const milli = Number(tempFile.text().trim());
            if (milli > 0) root.cpuTemp = milli / 1000;

            root.gpuAwake = gpuPowerState.text().trim() === "active";
            if (root.gpuAwake && !gpuQuery.running) gpuQuery.running = true;
        }
    }
}
