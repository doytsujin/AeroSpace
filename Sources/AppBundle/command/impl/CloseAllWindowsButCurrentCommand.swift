import AppKit
import Common

struct CloseAllWindowsButCurrentCommand: Command {
    let args: CloseAllWindowsButCurrentCmdArgs

    func run(_ env: CmdEnv, _ io: CmdIo) -> Bool {
        check(Thread.current.isMainThread)
        guard let focus = args.resolveFocusOrReportError(env, io) else { return false }
        guard let focused = focus.windowOrNil else {
            return io.err("Empty workspace")
        }
        guard let workspace = focused.workspace else {
            return io.err("Focused window '\(focused.title)' doesn't belong to workspace")
        }
        var result = true
        for window in workspace.allLeafWindowsRecursive where window != focused {
            result = CloseCommand(args: args.closeArgs).run(env, io) && result
        }
        return result
    }
}
