class TaskSpaceRepositoryMemory: TaskSpaceRepository {
    func Load() -> TaskSpaceDto {
        return TaskSpaceDto(tasks: [], projects: [], tags: [])
    }
    
    func Save(space: TaskSpaceDto) {
    }
}

var projectSelectorState = ProjectSelectorState()
var commandBus = createCommandBus(space: Space(TaskSpaceRepositoryMemory()), projectSelectorState: projectSelectorState)
