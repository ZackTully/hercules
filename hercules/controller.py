from hercules.control_methods.control_methods import Example06


class Controller:
    def __init__(self, input_dict):
        self.controller_dict = {}
        self.control_method = (
            Example06()
        )  # this can be replaced with a different control logic method depending on the situation.

    def step(self, main_dict):
        self.control_method.step(main_dict)

    def get_controller_dict(self):
        return self.control_method.get_controller_dict()


